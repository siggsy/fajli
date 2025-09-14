import os
import json
import argparse
import sys
from pathlib import Path
import subprocess

from collections import OrderedDict

from .utils import Fajli
from .commands import generate, get, update, edit, rekey

# ,-----------------------------------------------------------------------------
# | CLI
# '-----------------------------------------------------------------------------

parser = argparse.ArgumentParser(
    prog='fajli',
    description='Declerative file generator',
)
subparsers = parser.add_subparsers(help="subcommand help", dest='command')

parser_generate = subparsers.add_parser('generate', parents=[])
parser_get = subparsers.add_parser('get', parents=[])
parser_rekey = subparsers.add_parser('rekey', parents=[])
parser_set = subparsers.add_parser('set', parents=[])
parser_edit = subparsers.add_parser('edit', parents=[])
parser_dump = subparsers.add_parser('dump', parents=[])

# --  Global  ------------------------------------------------------------------

parser.add_argument('-i', '--identity', action='append', default=[], help='specify extra identities when decrypting')
parser.add_argument('-p', '--path', action='store', help='override generated folders path')

# --  Generate  ----------------------------------------------------------------

parser_generate.add_argument('-F', '--force', action='store_true', help='generate files even if they already exist')
parser_generate.add_argument('-f', '--folder', action='append', default=[], required=False, help='explicit list of folders to generate/regenerate')

# --  Get/set  -----------------------------------------------------------------

parser_get.add_argument('file_path', help='File to (decrypt and) print')
parser_set.add_argument('file_path', help='File to modify')
parser_edit.add_argument('file_path', help='File to edit')

# ,-----------------------------------------------------------------------------
# | Main
# '-----------------------------------------------------------------------------

def main() -> int:
    args = parser.parse_args()
    config_path = os.environ.get("FAJLI_CONFIG")

    if not config_path:
        sys.exit("Missing FAJLI_CONFIG environment variable.", file=sys.stderr)

    with open(config_path, "r") as c:
        config = json.load(c)
    
    path = args.path or config['path']

    # --  Setup environment  ---------------------------------------------------

    if not args.path:
        cwd = Path(os.getcwd())
        git_proc = subprocess.Popen(
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE,
            cwd = cwd.resolve(),
            args = [ "git", "rev-parse", "--show-toplevel"]
        )
        out, err = git_proc.communicate()
        ret = git_proc.wait()
        is_git = ret == 0

        if is_git:
            proj_root = Path(out.rstrip().decode('utf-8'))
        else:
            proj_root = cwd
        
        fajli_path = Path(proj_root / path).resolve()
        
        if proj_root.resolve() not in fajli_path.parents:
            print("Specified path falls out of the project. Exiting ...")
            return 1

    else:
        fajli_path = Path(path)
        proj_root = fajli_path.parent

    os.environ['FAJLI_PROJ_ROOT'] = str(proj_root.resolve())
    os.environ['FAJLI_PATH'] = str(fajli_path.resolve())

    fajli = Fajli(path=fajli_path, config=config, identities=args.identity)

    match args.command:
        case 'generate':
            generate(fajli=fajli, folders=list(map(Path, args.folder)))
        case 'rekey':
            rekey(fajli=fajli)
        case 'get':
            content = get(fajli=fajli, file=Path(args.file_path))
            print(content)
            return 0
        case 'set':
            update(fajli=fajli, out_file=Path(args.file_path))
            return 0
        case 'edit':
            edit(fajli=fajli, out_file=Path(args.file_path))
        case 'dump':
            json.dump(config, sys.stdout)
            return 0
        case _:
            parser.print_usage(file=sys.stderr)
            return 1
