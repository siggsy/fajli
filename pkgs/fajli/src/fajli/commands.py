
from pathlib import Path
import shutil
import os
import subprocess
import tempfile
import sys

from .utils import Fajli


def generate(
    fajli: Fajli,
) -> int:
    with fajli.transactional():
        for folder in fajli:
            print(f"[ Generating {folder.name} ]")
            if not folder.generate():
                print(f"Folder {folder.name} already exists. Skipping ...")
            for file in folder:
                file.decrypt()
            for file in folder:
                file.encrypt()

def modify_with(
    fajli: Fajli,
    file: Path,
    modify
):
    file_abs = file.absolute()
    with fajli.transactional():
        file_found = False

        res = None
        for folder in fajli:
            for file in folder:
                file.decrypt()
                is_encrypted = file.age_enabled()
                matches_age = str(file_abs).endswith(f'{file.cfg['path']}.age')
                matches = str(file_abs).endswith(file.cfg['path'])

                if is_encrypted and matches_age or matches:
                    modified, res = modify(file.cfg['path'])
                    
                    if modified and is_encrypted:
                        file.encrypt(rekey=True)

                    break
            if res:
                break
        
        if not res:
            print(f"File {file_abs} is not a part of fajli")
            sys.exit(1)
        
        return res

def get(
    fajli: Fajli,
    file: Path,
) -> str:
    def modify(path: Path):
        with open(path, 'r') as f:
            return False, f.read()
        
    return modify_with(fajli, file, modify)

def update(
    fajli: Fajli,
    out_file: Path,
    in_file = os.sys.stdin,
):
    def modify(path: Path):
        if in_file.isatty():
            print("Enter file contents (ctrl-d when done):")
        with open(path, 'w') as f:
            f.write(in_file.read())
        return True, True

    modify_with(fajli, out_file, modify)


def edit(
    fajli: Fajli,
    out_file: Path,
):
    def modify(path: Path):
        editor = os.environ.get('EDITOR') or sys.exit("Missing EDITOR environment")
        subprocess.call(args=[ editor, path])
        return True, True

    modify_with(fajli, out_file, modify)
