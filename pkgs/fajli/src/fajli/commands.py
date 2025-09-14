
from pathlib import Path
import shutil
import os
import subprocess
import tempfile

from fajli.utils import transactional
from fajli.folders import Fajli

def generate(
    fajli: Fajli,
) -> int:
    with transactional(fajli.path) as workdir:
        for folder, folder_cfg in fajli:
            fajli.generate(workdir, folder_cfg)
            fajli.decrypt(workdir, folder_cfg)
            fajli.encrypt(workdir, folder_cfg)

def get(
    fajli: Fajli,
    file: Path,
) -> str:

    with transactional(fajli.path) as workdir:
        for folder, folder_cfg in fajli:
            fajli.decrypt(workdir, folder_cfg)

            for file_name, file_cfg in folder_cfg['files'].items():
                is_encrypted = file_cfg['age']['enable']
                matches_age = str(file.absolute()).endswith(f'{file_cfg['path']}.age')
                matches = str(file.absolute()).endswith(file_cfg['path'])

                if is_encrypted and matches_age or matches:
                    with open(workdir / file_cfg['path'], 'r') as f:
                        return f.read()

        print(f"File {file} is not a part of fajli")
        sys.exit(1)

def set(
    fajli: Fajli,
    out_file: Path,
    in_file = os.sys.stdin,
) -> int:
    with transactional(fajli.path) as workdir:
        file_found = False

        for folder, folder_cfg in fajli:
            fajli.decrypt(workdir, folder_cfg)

            for file_name, file_cfg in folder_cfg['files'].items():
                is_encrypted = file_cfg['age']['enable']
                matches_age = str(out_file.absolute()).endswith(f'{file_cfg['path']}.age')
                matches = str(out_file.absolute()).endswith(file_cfg['path'])

                if is_encrypted and matches_age or matches:
                    if in_file.isatty():
                        print("Enter file contents (ctrl-d when done):")
                    with open(workdir / file_cfg['path'], 'w') as f:
                        f.writelines(in_file)
                    
                    if is_encrypted:
                        (workdir / f'{file_cfg['path']}.age').unlink()
                        fajli.encrypt(workdir, folder_cfg)

                    file_found = True
                    break
            
            if file_found:
                break
