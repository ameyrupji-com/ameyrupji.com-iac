import os
import shutil
import sys
import zipfile


def package_lambdas(directory, file_pattern):
    zipped_directory = directory + 'zipped/'
    
    shutil.rmtree(zipped_directory, ignore_errors=True)
    for root, dirs, files in os.walk(directory):
        os.makedirs(zipped_directory)
        for file in files:
            print('Zipping: `' + os.path.join(root + file))
            with zipfile.ZipFile(zipped_directory + file + '.zip', 'w', zipfile.ZIP_DEFLATED) as my_zip:
                print(' Added file `' + file + '`')

                my_zip.write(directory + file, './' + file)
            
if __name__ == "__main__":
    print('Supplied args...')
    for arg in sys.argv[1:]:
        print(arg)
    
    print('Starting zipping lambda functions...')
    directory = './lambdas/'
    package_lambdas(directory, '.py')

    print('Zipping finished!')