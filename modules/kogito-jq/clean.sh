#!/bin/bash

microdnf clean all
# segmentation full if delete /yum dir.
rm -rf /var/cache/dnf
