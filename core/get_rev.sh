#!/bin/sh

magic='--calling-python-from-shell--'
"""exec" python -E "$0" "$@" """#$magic"

if __name__ == '__main__':
  import sys
  if sys.argv[-1] == '#%s' % magic:
    del sys.argv[-1]
del magic

import optparse
import os
import readline
import subprocess
import sys
import xml.dom.minidom
import re

MANIFEST_FILE_NAME = 'manifest.xml'
LOCAL_MANIFEST_NAME = 'local_manifest.xml'

class ManifestParseError(Exception):
  """Failed to parse the manifest file.
  """

class Remote(object):
  def __init__(self, name,
               fetch=None,
               review=None,
               projectName=None):
    self.name = name
    self.fetchUrl = fetch
    self.reviewUrl = review
    self.projectName = projectName
    self.requiredCommits = []


class Project(object):
  def __init__(self,
               manifest,
               name,
               remote,
               gitdir,
               worktree,
               relpath,
               revision,
               upstream = ''):
    self.manifest = manifest
    self.name = name
    self.remote = remote
    self.gitdir = gitdir
    self.worktree = worktree
    self.relpath = relpath
    self.revision = revision
    self.snapshots = {}
    self.extraRemotes = {}
    self.copyfiles = []
    self.upstream = upstream

  @property
  def Exists(self):
    return os.path.isdir(self.gitdir)

class MetaProject(Project):
  """A special project housed under .repo.
  """
  def __init__(self, manifest, name, gitdir, worktree):
    repodir = manifest.repodir
    Project.__init__(self,
                     manifest = manifest,
                     name = name,
                     gitdir = gitdir,
                     worktree = worktree,
                     remote = Remote('origin'),
                     relpath = '.repo/%s' % name,
                     revision = 'refs/heads/master')

class _Default(object):
  """Project defaults within the manifest."""

  revision = None
  remote = None
  upstream = None

class Manifest(object):
  """manages the repo configuration file"""

  def __init__(self, manifest_file ):
    self.manifestFile = manifest_file
    self._Unload()

  @property
  def projects(self):
    self._Load()
    return self._projects

  @property
  def remotes(self):
    self._Load()
    return self._remotes

  @property
  def default(self):
    self._Load()
    return self._default

  def _Unload(self):
    self._loaded = False
    self._projects = {}
    self._remotes = {}
    self._default = None

  def _Load(self):
    if not self._loaded:
      self._ParseManifest(True)
      self._loaded = True

  def _ParseManifest(self, is_root_file):
    root = xml.dom.minidom.parse(self.manifestFile)
    if not root or not root.childNodes:
      raise ManifestParseError, \
            "no root node in %s" % \
            self.manifestFile

    config = root.childNodes[0]
    if config.nodeName != 'manifest':
      raise ManifestParseError, \
            "no <manifest> in %s" % \
            self.manifestFile

    for node in config.childNodes:
      if node.nodeName == 'remove-project':
        name = self._reqatt(node, 'name')
        try:
          del self._projects[name]
        except KeyError:
          raise ManifestParseError, \
                'project %s not found' % \
                (name)

    for node in config.childNodes:
      if node.nodeName == 'remote':
        remote = self._ParseRemote(node)
        if self._remotes.get(remote.name):
          raise ManifestParseError, \
                'duplicate remote %s in %s' % \
                (remote.name, self.manifestFile)
        self._remotes[remote.name] = remote

    for node in config.childNodes:
      if node.nodeName == 'default':
        if self._default is not None:
          raise ManifestParseError, \
                'duplicate default in %s' % \
                (self.manifestFile)
        self._default = self._ParseDefault(node)
    if self._default is None:
      self._default = _Default()

    for node in config.childNodes:
      if node.nodeName == 'project':
        project = self._ParseProject(node)
        if self._projects.get(project.name):
          raise ManifestParseError, \
                'duplicate project %s in %s' % \
                (project.name, self.manifestFile)
        self._projects[project.name] = project

    for node in config.childNodes:
      if node.nodeName == 'add-remote':
        pn = self._reqatt(node, 'to-project')
        project = self._projects.get(pn)
        if not project:
          raise ManifestParseError, \
                'project %s not defined in %s' % \
                (pn, self.manifestFile)
        self._ParseProjectExtraRemote(project, node)

  def _ParseRemote(self, node):
    """
    reads a <remote> element from the manifest file
    """
    name = self._reqatt(node, 'name')
    fetch = self._reqatt(node, 'fetch')
    review = node.getAttribute('review')
    if review == '':
      review = None

    projectName = node.getAttribute('project-name')
    if projectName == '':
      projectName = None

    r = Remote(name=name,
               fetch=fetch,
               review=review,
               projectName=projectName)

    for n in node.childNodes:
      if n.nodeName == 'require':
        r.requiredCommits.append(self._reqatt(n, 'commit'))

    return r

  def _ParseDefault(self, node):
    """
    reads a <default> element from the manifest file
    """
    d = _Default()
    d.remote = self._get_remote(node)
    d.revision = node.getAttribute('revision')
    if d.revision == '':
      d.revision = None

    #d.upstream = self._reqatt( node, 'upstream')
    d.upstream = node.getAttribute('upstream')
    return d

  def _ParseProject(self, node):
    """
    reads a <project> element from the manifest file
    """ 
    name = self._reqatt(node, 'name')

    remote = self._get_remote(node)
    if remote is None:
      remote = self._default.remote
    if remote is None:
      raise ManifestParseError, \
            "no remote for project %s within %s" % \
            (name, self.manifestFile)

    revision = node.getAttribute('revision')
    if not revision:
      revision = self._default.revision
    if not revision:
      raise ManifestParseError, \
            "no revision for project %s within %s" % \
            (name, self.manifestFile)

    #>>>by johnny
    #upstream: None means using default upstream. empty string means no upstream
    if node.hasAttribute('upstream') :
      upstream = node.getAttribute('upstream')
    else:
      upstream = self._default.upstream
    #<<<<

    path = node.getAttribute('path')
    if not path:
      path = name
    if path.startswith('/'):
      raise ManifestParseError, \
            "project %s path cannot be absolute in %s" % \
            (name, self.manifestFile)

    project = Project(manifest = self,
                      name = name,
                      remote = remote,
                      gitdir = "",
                      worktree = "",
                      relpath = path,
                      revision = revision,
                      upstream = upstream)

    for n in node.childNodes:
      if n.nodeName == 'remote':
        self._ParseProjectExtraRemote(project, n)

    return project

  def _ParseProjectExtraRemote(self, project, n):
    r = self._ParseRemote(n)
    if project.extraRemotes.get(r.name) \
       or project.remote.name == r.name:
      raise ManifestParseError, \
            'duplicate remote %s in project %s in %s' % \
            (r.name, project.name, self.manifestFile)
    project.extraRemotes[r.name] = r

  def _get_remote(self, node):
    name = node.getAttribute('remote')
    if not name:
      return None

    v = self._remotes.get(name)
    if not v:
      raise ManifestParseError, \
            "remote %s not defined in %s" % \
            (name, self.manifestFile)
    return v

  def _reqatt(self, node, attname):
    """
    reads a required attribute from the node.
    """
    v = node.getAttribute(attname)
    if not v:
      raise ManifestParseError, \
            "no %s in <%s> within %s" % \
            (attname, node.nodeName, self.manifestFile)
    return v
 
def _main(orig_args):
  init_optparse = optparse.OptionParser(usage="get-rev -m <manifest-file> <project-name>", version="%prog 1.0" )

# Manifest
  group = init_optparse.add_option_group('Manifest options')
  group.add_option('-m', '--manifest-file', 
                 dest='manifest_file', 
                 help='specify the manifest file that will be used to get revision of a project.', metavar='FILE')

  opt, args = init_optparse.parse_args(orig_args)

  if len(args) != 1:
    print("project name is not specified.")
    init_optparse.print_help()
    return 128

  project_name = args[0]  
  manifest = Manifest(opt.manifest_file)
  all = manifest.projects.values()
  for p in all:
    if project_name == p.name:
      print(p.revision)
      return 0

  print >> sys.stderr, "can't find the project:%s" % project_name
  return 1

if __name__ == "__main__":
    rlt = _main( sys.argv[1:] )
    sys.exit(rlt)

