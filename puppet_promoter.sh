#!/bin/bash

#This script will pull Puppet modules and changes from the GitLAb repo and
#sync the repo, publish to the content view, and promote to Library the changes.
#This is for Satellite 6 only. :)
#Version: 0.1
#Author: Robert Lupinek
#Date Modified by: 3/17/2015 Robert Lupinek
#Usage: ./puppet_promoter


#Temporary directory to download repo to
tmp_dir='/var/tmp'
#Repo folder
repo_dir='/var/opt/puppet_staging'
#Git uri
#git_uri=$1
git_uri='git@thehost:the_group/the_repo.git'
#Project name - this is what the folder 
project_name=`echo $git_uri | awk -F/ '{print $2}' | awk -F. '{print $1}'`

#Specify the content view
content_view="Puppet"
organization="Unix"
product="Puppet"
repo="PUPPET"
promote_life_cycle_env="Test"

#Check to see if the temp directory for the project exists and if it does remove it.
if [ -d $tmp_dir/$project_name ]
then
	echo "Clean up the staging directory..."
	rm -rf $tmp_dir/$project_name
fi

#Start building pulp friendly puppet modules for the Git repo:
cd $tmp_dir
pulp-puppet-module-builder --output-dir=$repo_dir --url="$git_uri"

#Syncronize the repo
hammer repository synchronize --organization="$organization" --product="$product" --name="$repo"
#Publish new content view
hammer content-view publish --name="$content_view" --organization="$organization"





