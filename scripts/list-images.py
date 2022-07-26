#!/usr/bin/python3
# Script responsible to update the tests with
# Should be run from root directory of the repository


import argparse
import sys

import common

sys.dont_write_bytecode = True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Kogito Version Manager - List Images by Community and Product version')
    parser.add_argument('--prod', default=False, action='store_true', help='List product images')
    parser.add_argument('-s', '--supporting-services', default=False, action='store_true',
                        help='List Supporting Services images')
    parser.add_argument('-is', '--is-supporting-services', default=False, type=str,
                        help='Query the given image, if found exit 0, otherwise exit 10.')

    args = parser.parse_args()

    images = []
    if args.prod:
        images = common.get_prod_images()
    elif args.supporting_services:
        if args.is_supporting_services:
            exit(common.is_supporting_services_image(args.is_supporting_services))
        else:
            images = common.get_supporting_services_images()
    else:
        images = common.get_community_images()

    for img in sorted(images):
        print(img)
