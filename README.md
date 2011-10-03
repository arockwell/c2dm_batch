C2dmBatch
===========

A gem template for new projects.

Requirements
------------

<pre>
gem install stencil
</pre>

Setup the template
------------------

You only have to do this once.

<pre>
git clone git@github.com:winton/c2dm_batch.git
cd c2dm_batch
stencil
</pre>

Setup a new project
-------------------

Do this for every new project.

<pre>
mkdir my_project
git init
stencil c2dm_batch
rake rename
</pre>

The last command does a find-replace (gem\_template -> my\_project) on files and filenames.