#!/bin/bash
pandoc "$1/$2" -f markdown -t html --template=template --toc -s -o "$1/$3"
