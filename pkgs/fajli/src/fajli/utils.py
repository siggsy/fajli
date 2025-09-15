from typing import Any
from collections import OrderedDict
from graphlib import TopologicalSorter
from pathlib import Path
import tempfile
import os
import subprocess
import shutil
from contextlib import contextmanager
import datetime
import sys

def expanded_path(path: str) -> Path:
    return Path(os.path.expandvars(path))

def git_root() -> Path | None:
    git_proc = subprocess.Popen(
        stdout = subprocess.PIPE,
        stderr = subprocess.PIPE,
        args = [ "git", "rev-parse", "--show-toplevel"]
    )
    out, err = git_proc.communicate()
    ret = git_proc.wait()
    return Path(out.rstrip().decode('utf-8')) if ret == 0 else None

class Fajli():
    def __init__(self, path: str, commit: bool, config: dict[str, Any], identities: list[str]):
        self.folders = toposort(config['folders'])
        self.identities = [ expanded_path(i) for i in identities + config['defaultIdentityFiles'] ]
        self.path = Path(path)
        self.commit = commit

    def __iter__(self):
        return map(lambda p: Folder(self, p[0], p[1]), self.folders.items())

    @contextmanager
    def transactional(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            workdir = Path(tmpdir)
            if self.path.exists():
                workdir.rmdir()
                shutil.copytree(self.path, workdir)
            
            old = os.getcwd()
            os.chdir(workdir)
            yield workdir

            for folder in self:
                for file in folder:
                    if not file.cfg['age']['enable']:
                        continue
                        
                    f = Path(file.cfg['path'])
                    if f.exists():
                        f.unlink()

            os.chdir(old)

            shutil.rmtree(self.path, ignore_errors=True)
            shutil.move(workdir, self.path)

            if not self.commit:
                return

            root = git_root()
            if not root:
                return

            if subprocess.call(args = [ 'git', 'add', self.path ]) != 0:
                sys.exit('Failed to run git add')

            diff_proc = subprocess.Popen(
                stdout = subprocess.PIPE,
                stderr = subprocess.PIPE,
                args = [ 'git', 'diff', '--staged', '--minimal', self.path ]
            )
            out, err = diff_proc.communicate()
            if diff_proc.wait() != 0:
                sys.exit('failed to run git diff')
            if not out.rstrip().decode('utf-8'):
                return

            if subprocess.call(args = [
                'git', 'commit', '-m',
                f'Fajli changes @ {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}' ]
            ) != 0:
                sys.exit('Falied to run git commit')

    
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


class Folder():
    def __init__(self, fajli: Fajli, folder: str, folder_cfg: dict[str, Any]):
        self.name = folder
        self.cfg = folder_cfg
        self.fajli = fajli
    
    def __iter__(self):
        return map(lambda p: File(self.fajli, p[0],p[1]), self.cfg['files'].items())
    
    def generate(self, force: bool = False):
        with tempfile.TemporaryDirectory() as tmpdir, tempfile.TemporaryDirectory() as out:
            folder_path = Path(self.cfg['path'])
            if folder_path.exists() and not force:
                return False

            retained = { k: os.environ[k] for k in ['FAJLI_PATH', 'FAJLI_PROJ_ROOT'] }
            env = retained | {
                'PATH': os.environ.get('FAJLI_STDENV'),
                'out': str(out),
            }

            script = '''
            set -euo pipefail

            '''
            script += self.cfg['script']
            
            ret = subprocess.call(
                env = env,
                cwd = tmpdir,
                args = [ "bash", "-c", script ]
            )

            for file in self:
                file_path = Path(str(out)) / file.name
                final_path = Path(file.cfg['path'])
                final_path.parent.mkdir(parents=True, exist_ok=True)
                if file_path.exists():
                    shutil.copy(file_path, final_path)
                else:
                    sys.exit(f'Script did not generate file {file.name}')
            
            if ret != 0:
                sys.exit(f'Script failed when generating folder {folder_path}')
        
        return True


class File():
    def __init__(self, fajli: Fajli, name: str, cfg: dict[str, Any]):
        self.name = name
        self.cfg = cfg
        self.fajli = fajli
    
    def identities(self) -> list[Path]:
        return self.fajli.identities + [ expanded_path(i) for i in self.cfg['age']['identityFiles'] ]
    
    def age_enabled(self):
        return self.cfg['age']['enable']

    def encrypt(self, rekey=False):
        if not self.age_enabled():
            return

        file_org = Path(self.cfg['path'])
        file_enc = Path(f'{self.cfg['path']}.age')

        if not file_enc.exists() or rekey:
            ident_args = []
            if self.cfg['age']['symmetric']:
                for ident in self.identities():
                    ident_args += [ "-i", ident.as_posix() ]
            else:
                for rec in self.cfg['age']['recipients']:
                    match rec['type']:
                        case 'literal': 
                            ident_args += [ "-r", rec['value'] ]
                        case 'path':
                            ident_args += [ "-R", rec['value'] ]

            ret = subprocess.call(
                args = [
                    "age", "--armor", "--encrypt", *ident_args,
                    "-o", file_enc.resolve(), file_org.resolve()
                ]
            )

            if ret != 0:
                sys.exit(f"Failed encrypting file {cfg['path']}")

    def decrypt(self):
        if not self.age_enabled():
            return

        file_org = Path(self.cfg['path'])
        file_enc = Path(f'{self.cfg['path']}.age')

        if file_enc.exists() and not file_org.exists():
            ident_args = []
            for ident in self.identities():
                ident_args += [ "-i", ident.as_posix() ]

            ret = subprocess.call(
                env = {
                    'PATH': os.environ.get('FAJLI_STDENV'),
                },
                args = [
                    "age", "--decrypt", *ident_args,
                    "-o", file_org.resolve(), file_enc.resolve()
                ]
            )

            if ret != 0:
                sys.exit(f"Failed decrypting file {self.cfg['path']}")
