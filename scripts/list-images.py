#!/usr/bin/python3
# Script responsible to update the tests with
# Should be run from root directory of the repository
# Sample usage:  python3 scripts/update-tests.py

import argparse
import sys

import common

sys.dont_write_bytecode = True

PRODUCT_PREFIX = "rhpam"

# map community images with its correlative product
images_map = {'rhpam-kogito-builder-rhel8': 'kogito-builder',
              'rhpam-kogito-runtime-jvm-rhel8': 'kogito-runtime-jvm'}

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Kogito Version Manager - List Images by Community and Product version')
    parser.add_argument('--prod', default=False, action='store_true', help='List product images')
    parser.add_argument('--parent-image', dest='parent_image', help='Return the correspondent community image.')

    args = parser.parse_args()

    if args.parent_image:
        print(images_map[args.parent_image])
    else:
        for img in sorted(common.get_all_images()):
            if img.startswith(PRODUCT_PREFIX) and args.prod:
                print(img)
            elif not img.startswith(PRODUCT_PREFIX) and not args.prod:
                print(img)
