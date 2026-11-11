#!/bin/sh
redo-ifchange $(ls -d */ | sed 's|/$|.pkg|')
