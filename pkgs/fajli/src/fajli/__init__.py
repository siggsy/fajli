import os
import json
import argparse
import sys
from pathlib import Path

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
parser_set = subparsers.add_parser('set', parents=[])
parser_edit = subparsers.add_parser('edit', parents=[])
parser_dump = subparsers.add_parser('dump', parents=[])

# --  Global  ------------------------------------------------------------------

parser.add_argument('-i', '--identity', action='append', help='specify extra identities when decrypting')
parser.add_argument('-p', '--path', action='store', help='override generated folders path')
parser.add_argument('-c', '--config', action='store', default=os.environ.get("FAJLI_CONFIG"), help='read this file for definitions (overrides FAJLI_CONFIG environment)')

# --  Generate  ----------------------------------------------------------------

parser_generate.add_argument('-f', '--force', action='store_true', help='generate files even if they already exist')
parser_generate.add_argument('-r', '--rekey', action='store_true', help='rekey encrypted files')

# ,-----------------------------------------------------------------------------
# | Main
# '-----------------------------------------------------------------------------

def main() -> int:
    args = parser.parse_args()

    if not args.config:
        print("Missing config file path (FAJLI_CONFIG or --config)", file=sys.stderr)
        parser.print_usage(file=sys.stderr)
        return 1

    with open(args.config, "r") as c:
        config = json.load(c)
    
    match args.command:
        case 'generate':
            generator.generate(
                folders=config['folders'], path=Path(args.path),
                rekey=args.rekey, identities=args.identity + config['identities'],
            )
            return 0
        case 'get':
            files.get(Path(args.path), identities=args.identity + config['identities'])
            return 0
        case 'set':
            files.set(Path(args.path), identities=args.identity + config['identities'])
            return 0
        case 'edit':
            files.edit(Path(args.path), identities=args.identity + config['identities'])
            return 0
        case 'dump':
            json.dump(config, sys.stdout)
            return 0
        case _:
            parser.print_usage(file=sys.stderr)
            return 1
