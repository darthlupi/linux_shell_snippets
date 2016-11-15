#!/bin/bash

#This script will pull Puppet modules and changes from a GitLAb repo and
#sync the repo, publish to the content view, and promote to Library the changes.
#Tge 
#Version: 0.1
#Author: Robert Lupinek
#Date Modified by: 3/17/2015 Robert Lupinek
#Usage: ./sat_6_promoter


#Temporary directory to download repo to
tmp_dir='/var/tmp'
#Repo folder
repo_dir='/var/opt/puppet_staging'
#Git uri
#git_uri=$1
git_uri='GIT_URI'
#Project name - this is what the folder 
project_name=`echo $git_uri | awk -F/ '{print $2}' | awk -F. '{print $1}'`

#Specify the content view
content_view="Puppet"
organization="Linux"
product="uppet"
repo="Puppet"
promote_life_cycle_env="Test"

#Check to see if the temp directory for the project exists and if it does remove it.
if [ -d $tmp_dir/$project_name ]
then
	echo "Clean up the staging directory..."
	rm -rf $tmp_dir/$project_name
fi

#Start building pulp friendly puppet modules for the Git repo:
cd $tmp_dir

echo "Prepare Repo..."
pulp-puppet-module-builder --output-dir=$repo_dir --url="$git_uri"

#Syncronize the repo
echo "Synchronize repo..."
hammer repository synchronize --organization="$organization" --product="$product" --name="$repo"

#No point publishing the content view until we select the modules for it.
#This is useless for adds.
#Publish new content view
#echo "Publish Content View..."
#hammer content-view publish --name="$content_view" --organization="$organization"

#Below is incomplete code.  This will promote the latest version the lifecycle environment
#that is set in the variable promote_life_cycle_env.  Currently it is failing due 

#Get the latest content view version
#latest_content_version=`hammer content-view version list --content-view="$content_view" --organization="$organization" | head -n 4 | grep "$content_view" | awk -F\| '{print $1}'`
#Promote the latest build to desired life cycle
#hammer content-view version promote --id $latest_content_version --content-view="$content_view" --lifecycle-environment="promote_life_cycle_env" --organization="$organization" 
