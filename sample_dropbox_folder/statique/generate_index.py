#!/usr/bin/python

"""
* Generates index.md for each folder recursively
* Compiles all markdown files into html in the same folder.
"""
import os
import re
import datetime
import time
import subprocess
import logging

def md2html(dirName, md):
    """
    Calls markdown to HTML script.
    """
    html = md[:-2]+"html"
    subprocess.call(["sh","md2html.sh",dirName, md, html])
    if not os.path.exists(os.path.join(dirName, html)):
        logging.warning("MD2HTML Compilation Error on: %s/%s" %(dirName, md))

def process(rootDir):
    """
    Traverses a given path recursively
        * finds markdown files (pages), other files, subdirectories
        * for each page, generates html from md
        * generates an index page for each directory.
    """
    for dirName, subdirList, fileList in os.walk(rootDir):
        relative_path = dirName[len(rootDir):]
        mds = sorted([fname for fname in fileList if fname.endswith(".md") and fname != "index.md" ])
        md_htmls = [fname[:-2]+"html" for fname in mds]
        hidden_files = [fname for fname in fileList if fname.startswith(".")]
        files = sorted(list(set(fileList) - set(mds) - set(["index.md", "index.html"]) - set(md_htmls) - set(hidden_files)))
        subdirs = sorted([dname for dname in subdirList if not dname.startswith(".")])

        logging.debug('Traversing directory: %s' % dirName)

        index_file = os.path.join(dirName, "index.md")
        directory_name = dirName.split("/")[-1].capitalize()
        if fileList or subdirList:
            write_index(rootDir.split("/")[-1], index_file, relative_path, directory_name, subdirs, mds, files)
        if os.path.exists(index_file):
            mds.append("index.md")
        for md in mds:
            md2html(dirName, md)

def generate_breadcrumb(path):
    """
    Generates breadcrumb for the given path.
    """
    # If empty path given, return empty string.
    if not path:
        return ""
    parts = path.split("/")

    # If it's root, return empty string
    if not parts[0]:
        return ""

    # If it's a regular path, create breadcrumb items
    o = '<ol class="breadcrumb" style="margin-bottom: 5px;">\n'
    for i in xrange(0, len(parts)-1):
        o += '<li><a href="%s">%s/</a></li>\n' % ("/"+"/".join(parts[0:i+1]), parts[i])

    # write the last one
    o += '<li class="active"><a href="/%s/">%s</a></li>' % (path, parts[-1])
    o += '</ol>'
    return o


def write_index(root_dir, index_file, relative_path, directory_name, subdirs, pages, files):
    """
    Writes the index.html for the given directory.
    Suppose we want to generate index for folder /a/b/ch_test/
    @root_dir: root parent folder name at the top level. Ex: a
    @index_file: $CONTENT_PATH/a/b/ch_test/index.md
    @relative_path: /b/ch_test
    @directory_name: Ch_test
    @subdirs: subdirectory names under ch_test
    @pages: markdown files under ch_test
    @files: other files under ch_test
    """
    logging.debug("root_dir: %(root_dir)s\nindex_file: %(index_file)s\nrelative_path: %(relative_path)s\ndirectory_name: %(directory_name)s\nsubdirs: %(subdirs)s" % locals())
    with open(index_file, "w") as index:
        index.write(generate_breadcrumb(root_dir + relative_path))
        if subdirs:
            index.write('<div class="panel panel-warning"><div class="panel-heading"><h3>Subdirectories</h3></div><div class="panel-body">\n')
            for subdir in subdirs:
                title = subdir
                line = '* <a href="./%(subdir)s/">%(title)s</a>\n' % {'title': title, 'subdir': subdir}
                index.write(line)
            index.write("</div></div>")

        if pages:
            index.write('<div class="panel panel-info"><div class="panel-heading"><h3>Pages</h3></div><div class="panel-body">\n')
            for fname in pages:
                title = fname.replace("_", " ").replace(".md", "").capitalize()
                url = os.path.join(relative_path, fname)
                html = fname[:-2] + "html"
                line = '* [%(title)s](%(fname)s)\n' % {'title': title, 'fname': html}
                index.write(line)
            index.write("</div></div>")

        if files:
            index.write('<div class="panel panel-primary"><div class="panel-heading"><h3>Files</h3></div><div class="panel-body">\n')
            for fname in files:
                url = os.path.join(relative_path, fname)
                line = '* <a href="./%(fname)s">%(fname)s</a>\n' % {'fname': fname}
                index.write(line)
            index.write("</div></div>")


def generate_indices(content_folder):
    # TODO: these are not folders, we should check it.
    folders = sorted(os.listdir(content_folder))
    for folder in folders:
        logging.info("Processing %s..." % folder)
        process(os.path.join(content_folder, folder))

    main_page = os.path.join(content_folder, "index.md")
    write_index("/", main_page, "/", "Main Page", folders, None, None)
    logging.info("Generating index for main page...")
    md2html(content_folder, "index.md")
    logging.info("Index generation completed.")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO,
                        format='[%(asctime)s] [%(levelname)s] %(message)s')
    generate_indices(content_folder = "/tmp/statique/content")
