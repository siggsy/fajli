from graphlib import TopologicalSorter

from pathlib import Path
import shutil
import os
import subprocess
import tempfile

class ModifiedEnviron():
    def __init__(self): ...
    def __enter__(self): self.old_env = os.environ.copy()
    def __exit__(self, *_): os.environ = self.old_env
        
def modified_environ(func):
    def f(*args, **kwargs):
        with ModifiedEnviron():
            func(*args, **kwargs)
    return f

@modified_environ
def generate(
    folders: dict[str, any],
    path: Path,
    rekey: bool,
    identities: list[str]
) -> int:

    # --  Setup environment  ---------------------------------------------------

    wd = Path(os.getcwd()) / path
    git_proc = subprocess.Popen(
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE,
        cwd = wd.absolute(),
        args = [ "git", "rev-parse", "--show-toplevel"]
    )
    out, err = git_proc.communicate()
    ret = git_proc.wait()
    is_git = ret == 0

    if is_git:
        proj_root = Path(out.rstrip().decode('utf-8'))
    else:
        proj_root = wd

    os.environ['FAJLI_PROJ_ROOT'] = str(proj_root.absolute())

    # --  Topologically sort folders  ------------------------------------------
    
    graph = { folder: set() for folder in folders.keys() }
    names = folders.keys()
    for folder, folder_cfg in folders.items():
        after_set = set()
        for a in folder_cfg['after']:
            if a in names:
                after_set.add(a)
            else:
                after_set |= set(filter(lambda f: f.startswith(a), names))
        
        graph[folder] |= after_set

        for b in folder_cfg['before']:
            if b in names:
                graph[b].add(folder)
            else:
                for bs in filter(lambda f: f.startswith(a), names):
                    graph[bs].add(folder)
    
    order = list(TopologicalSorter(graph).static_order())

    
    with tempfile.TemporaryDirectory() as workdir:
        workdir_path = Path(workdir)
        shutil.copytree(path, workdir_path, dirs_exist_ok=True)

        # --  Generate  --------------------------------------------------------

        for folder in order:
            folder_cfg = folders[folder]

            with tempfile.TemporaryDirectory() as tmpdir, tempfile.TemporaryDirectory() as out:
                folder_path = workdir_path / folder_cfg['path']
                if folder_path.exists():
                    print(f"Folder {folder} already exists. Skipping ...")
                    continue

                env = {
                    'PATH': os.environ.get('FAJLI_STDENV'),
                    'out': str(out),
                }

                script = '''
                set -euo pipefail

                '''
                script += folder_cfg['script']
                
                ret = subprocess.call(
                    env = env,
                    cwd = tmpdir,
                    args = [ "bash", "-c", script ]
                )

                for file_name, file_cfg in folder_cfg['files'].items():
                    file_path = Path(str(out)) / file_name
                    final_path = workdir_path / file_cfg['path']
                    final_path.parent.mkdir(parents=True, exist_ok=True)
                    if file_path.exists():
                        shutil.copy(file_path, final_path)
                    else:
                        print(f'Script did not generate file {file}')
                        return 1
                
                if ret != 0:
                    # TODO: inform which script failed
                    return ret
    
        # --  Encrypt  ---------------------------------------------------------
        
        for folder in order:
            folder_cfg = folders[folder]


            for file_name, file_cfg in folder_cfg['files'].items():
                if not file_cfg['age']['enable']:
                    continue

                file_org = workdir_path / file_cfg['path']
                file_enc = workdir_path / f'{file_cfg['path']}.age'

                if file_enc.exists() and not file_org.exists():
                    ident_args = []
                    for ident in list(map(lambda f: Path(os.path.expandvars(f)), identities + file_cfg['age']['identityFiles'])):
                        ident_args += [ "-i", ident.as_posix() ]

                    ret = subprocess.call(
                        cwd = workdir,
                        env = {
                            'PATH': os.environ.get('FAJLI_STDENV'),
                        },
                        args = [ "age", "--decrypt", *ident_args, "-o", file_org.absolute(), file_enc.absolute() ]
                    )

                    if ret != 0:
                        return ret
                
                if not file_enc.exists() or rekey:
                    ident_args = []
                    if file_cfg['age']['symmetric']:
                        for ident in list(map(lambda f: Path(os.path.expandvars(f)), identities + file_cfg['age']['identityFiles'])):
                            ident_args += [ "-i", ident.as_posix() ]
                    else:
                        for rec in file_cfg['age']['recipients']:
                            match rec['type']:
                                case 'literal': 
                                    ident_args += [ "-r", rec['value'] ]
                                case 'path':
                                    ident_args += [ "-R", rec['value'] ]

                    ret = subprocess.call(
                        cwd = workdir,
                        args = [ "age", "--armor", "--encrypt", *ident_args, "-o", file_enc.absolute(), file_org.absolute() ]
                    )

                    if ret != 0:
                        return ret

            
        # --  Cleanup plaintexts  ----------------------------------------------
        
        for folder_name, folder_cfg in folders.items():
            for file_name, file_cfg in folder_cfg['files'].items():
                if not file_cfg['age']['enable']:
                    continue
                    
                (workdir_path / file_cfg['path']).unlink()
        
        # --  Commit changes  --------------------------------------------------

        shutil.rmtree(path, ignore_errors=True)
        shutil.move(workdir_path, path)
        # TODO: git



        
        
