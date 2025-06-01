import os, argparse, requests, subprocess, tempfile, traceback, sys
from pathlib import Path

ANSI_RESET = '\033[0m'
ANSI_ULINE = '\033[4m'
ANSI_BOLD = '\033[1m'
ANSI_RED = '\033[31m'
ANSI_YLW = '\033[33m'
ANSI_BLK = '\033[30m'
ANSI_WHT_BG = '\033[47m'

VERSION = '0.0.2'

def check(config):
    # Normalizar la ruta usando Path para compatibilidad multiplataforma
    config = str(Path(config))
    cwd = os.getcwd()

    # Verificar si existe un repositorio local de haxelib
    haxelib_path = Path(cwd) / '.haxelib'
    project_xml = Path(cwd) / 'Project.xml'

    if haxelib_path.exists():
        if not project_xml.exists():
            print(f'{ANSI_RESET}{ANSI_ULINE}{ANSI_RED}No Project.xml detectado!{ANSI_RESET} {ANSI_BOLD}{ANSI_YLW}(¿Estás seguro de que estás ejecutando esto en el lugar correcto?){ANSI_RESET}')
    else:
        print(f'{ANSI_RESET}{ANSI_YLW}{ANSI_BOLD}No se detectó repositorio haxelib en el directorio actual!{ANSI_RESET} Las instalaciones irán a {ANSI_BLK}{ANSI_WHT_BG}{ANSI_BOLD}{config}{ANSI_RESET}')

    sscript_current = Path(config) / 'SScript' / '.current'
    if sscript_current.exists():
        command = input(f'{ANSI_RESET}{ANSI_YLW}{ANSI_BOLD}SScript ya está instalado!{ANSI_RESET} ¿Deseas eliminarlo? {ANSI_BOLD}[y/n]{ANSI_RESET} ').lower().strip()
        if command == 'y':
            current_version = sscript_current.read_text().strip()
            print(f'Intentando eliminar {ANSI_RESET}{ANSI_BOLD}SScript {current_version}{ANSI_RESET}...')

            try:
                subprocess.run(['haxelib', 'remove', 'SScript'], check=True)
            except subprocess.CalledProcessError as uninstall_exception:
                print(f'{ANSI_RESET}{ANSI_RED}Error al eliminar SScript{ANSI_RESET}')
                traceback.print_exception(uninstall_exception)
                sys.exit(1)
        elif command == 'n':
            print('SScript no será eliminado.')
        else:
            print(f'{ANSI_RESET}{ANSI_RED}Opción inválida{ANSI_RESET}: {command}')
            sys.exit(1)

def main():
    header = f'SScript Archive Installer [{VERSION}]'
    print('=' * (len(header) + 6), f'\n   {header}\n' + ('=' * (len(header) + 6)))

    try:
        haxepath = subprocess.run(['haxelib', 'config'], capture_output=True, text=True, check=True)
        haxeconfig = haxepath.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f'{ANSI_RESET}{ANSI_RED}Error al obtener la configuración de haxelib:{ANSI_RESET}\n{e.stderr}')
        return 1
    
    check(config=haxeconfig)

    parser = argparse.ArgumentParser(prog='SScript Archive Installer')
    parser.add_argument('version', help='SScript version to download')
    version = parser.parse_args().version.strip().lower().replace('.', ',')

    versionRequest = requests.get('https://api.github.com/repos/CobaltBar/SScript-Archive/contents/archives')
    versionRequest.raise_for_status()
    versionJson = versionRequest.json()

    versions = {versionJson[i]['name'].replace('SScript-', '').replace('.zip', '').strip().lower(): versionJson[i] for i in range(len(versionJson))}

    if not version in versions.keys():
        versionNames = [version for version in versions.keys()]

        def sort_versions(version_list):
            def version_key(version):
                return tuple(map(int, version.split('-')[0].split(',')))
            return sorted(version_list, key=version_key, reverse=True)

        versionNames = sort_versions(versionNames)

        version_table = []
        columns = 6
        for chunk in range(0, len(versionNames), columns):
            version_table.append([v.replace(',', '.') for v in versionNames[chunk:chunk + columns]])

        column_width = max(max(len(item) for item in row) for row in version_table) + 2
        print(f'{ANSI_RESET}{ANSI_BOLD}{ANSI_RED}Invalid version.{ANSI_RESET} Valid versions:')
        for row in version_table:
            print("".join(item.ljust(column_width) for item in row))

        return 1
    
    fileRequest = requests.get(versions[version]['download_url'])
    fileRequest.raise_for_status()

    with tempfile.TemporaryDirectory() as tmpDir:
        path = str(Path(tmpDir) / f'SScript-{version}.zip')

        with open(path, 'wb') as f:
            f.write(fileRequest.content)

        print(f'{ANSI_RESET}Intentando instalar {ANSI_BOLD}SScript-{str(version)}.zip{ANSI_RESET}')
        try:
            subprocess.run(['haxelib', 'install', path], check=True)
        except subprocess.CalledProcessError as install_exception:
            print(f'{ANSI_RESET}{ANSI_RED}Error en la instalación{ANSI_RESET}')
            traceback.print_exception(install_exception)
            return 1

    return 0

if __name__ == '__main__':
    sys.exit(main())