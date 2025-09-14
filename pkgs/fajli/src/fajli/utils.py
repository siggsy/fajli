from typing import Any
from collections import OrderedDict
from graphlib import TopologicalSorter
from pathlib import Path
import tempfile
import os
import subprocess
import shutil
from contextlib import contextmanager

class Fajli():
    def __init__(self, path: str, config: dict[str, Any], identities: list[str]):
        self.folders = toposort(config['folders'])
        self.identities = config['defaultIdentityFiles'] + identities
        self.path = Path(path)
    
    def identities_of(self, file_cfg: dict[str, Any]) -> list[Path]:
        return list(map(lambda f: Path(os.path.expandvars(f)), self.identities + file_cfg['age']['identityFiles']))

    def generate(self, workdir: Path, folder_cfg: dict[str, Any]):
        with tempfile.TemporaryDirectory() as tmpdir, tempfile.TemporaryDirectory() as out:
            folder_path = workdir / folder_cfg['path']
            if folder_path.exists():
                print(f"Folder {folder_cfg['name']} already exists. Skipping ...")
                return 0

            retained = { k: os.environ[k] for k in ['FAJLI_PATH', 'FAJLI_PROJ_ROOT'] }
            env = retained | {
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
                final_path = workdir / file_cfg['path']
                final_path.parent.mkdir(parents=True, exist_ok=True)
                if file_path.exists():
                    shutil.copy(file_path, final_path)
                else:
                    print(f'Script did not generate file {file}')
                    return 1
            
            if ret != 0:
                # TODO: inform which script failed
                return ret
    
    def encrypt(self, workdir: Path, folder_cfg: dict[str, Any], rekey=False):
        for file_name, file_cfg in folder_cfg['files'].items():
            if not file_cfg['age']['enable']:
                continue

            file_org = workdir / file_cfg['path']
            file_enc = workdir / f'{file_cfg['path']}.age'

            if not file_enc.exists() or rekey:
                ident_args = []
                if file_cfg['age']['symmetric']:
                    for ident in self.identities_of(file_cfg):
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


    def decrypt(self, workdir: Path, folder_cfg: dict[str, Any]):
        for file_name, file_cfg in folder_cfg['files'].items():
            if not file_cfg['age']['enable']:
                continue

            file_org = workdir / file_cfg['path']
            file_enc = workdir / f'{file_cfg['path']}.age'

            if file_enc.exists() and not file_org.exists():
                ident_args = []
                for ident in self.identities_of(file_cfg):
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

    def __iter__(self):
        return iter(self.folders.items())

    @contextmanager
    def transactional(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            workdir = Path(tmpdir)
            if self.path.exists():
                workdir.rmdir()
                shutil.copytree(self.path, workdir)
            yield workdir

            for folder_name, folder_cfg in self:
                for file_name, file_cfg in folder_cfg['files'].items():
                    if not file_cfg['age']['enable']:
                        continue
                        
                    f = workdir / file_cfg['path']
                    if f.exists():
                        f.unlink()

            shutil.rmtree(self.path, ignore_errors=True)
            shutil.move(workdir, self.path)

            # TODO: git

    
def toposort(folders: dict[str, Any]) -> OrderedDict[str, Any]:
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
    return OrderedDict([ (key, folders[key]) for key in order ])
