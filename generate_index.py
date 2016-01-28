import os
import re
import datetime
import time
import subprocess

def md2html(dirName, md):
    subprocess.call(["sh","md2html.sh",dirName, md, md[:-2]+"html"])

def process(rootDir):
    for dirName, subdirList, fileList in os.walk(rootDir):
        relative_path = dirName[len(rootDir):]

        mds = sorted([fname for fname in fileList if fname.endswith(".md") and fname != "index.md" ])
        md_htmls = [fname[:-2]+"html" for fname in mds]
        hidden_files = [fname for fname in fileList if fname.startswith(".")]
        files = sorted(list(set(fileList) - set(mds) - set(["index.md", "index.html"]) - set(md_htmls) - set(hidden_files)))
        subdirs = sorted([dname for dname in subdirList if not dname.startswith(".")])
        #print('Found directory: %s' % dirName)
        index_file = os.path.join(dirName, "index.md")
        directory_name = dirName.split("/")[-1].capitalize()
        if fileList or subdirList:
            write_index(rootDir.split("/")[-1], index_file, relative_path, directory_name, subdirs, mds, files)
        if os.path.exists(index_file):
            mds.append("index.md")
        for md in mds:
            md2html(dirName, md)

def generate_breadcrumb(path):
    if not path:
        return ""
    parts = path.split("/")
    if not parts[0]:
        return ""
    o = '<ol class="breadcrumb" style="margin-bottom: 5px;">\n'
    for i in xrange(0, len(parts)-1):
        o += '<li><a href="%s">%s</a></li>\n' % ("/"+"/".join(parts[0:i+1]), parts[i])
    o += '<li class="active"><a href="%s">%s</a></li>' % (path, parts[-1])
    o += '</ol>'
    return o

def write_index(root_dir, index_file, relative_path, directory_name, subdirs, pages, files):
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


def generate_indices():
    CONTENT_FOLDER = "/tmp/hugo/content"
    folders = filter(lambda x: x, map(lambda x: x.strip(), open("/tmp/hugo/config/include.txt").read().split("\n")))
    # TODO: these are not folders, we should check it.

    for folder in folders:
        print("Processing %s..." % folder)
        process(os.path.join(CONTENT_FOLDER, folder))

    main_index_0 = os.path.join(CONTENT_FOLDER, "index.md")
    write_index("/", main_index_0, "/", "Main Page", folders, None, None)
    md2html(CONTENT_FOLDER, "index.md")
    print("generated index.html")


if __name__ == "__main__":
    generate_indices()
