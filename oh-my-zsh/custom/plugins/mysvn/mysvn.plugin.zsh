# vim:ft=zsh ts=2 sw=2 sts=2
#

# diffs branchname with trunk and shows all changed files 
function svn_diff_trunk_summary() {
  branch=$1
  if [ -z "$branch" ]; then
    branch=$(svn_get_branch_name)
  fi
  svn diff --summarize --old '^/trunk' --new "^/branches/$branch" | grep "^[MAD]"
}

# diffs branch w/ trunk
function svn_diff_trunk() {
  branch=$1
  if [ -z "$branch" ]; then
    branch=$(svn_get_branch_name)
  fi
  svn diff --old '^/trunk' --new "^/branches/$branch"
}

# merges branch back into trunk
function svn_merge_to_trunk() {
  if [ "$(svn_get_branch_name)" != 'trunk' ]; then
    echo 'You must be on trunk'
    return
  fi

  branch=$1
  if [ -z "$branch" ]; then
    echo 'Dude. Set a branch name'
    return
  fi
  svn merge --reintegrate "^/branches/$branch"
}

# discards all files that only have svn mergeinfo changes
function svn_revert_property_changes() {
  echo
  
  while read line; do
    file=${line:7}
    svn revert $file
  done <<< "`svn status | grep '^ M      '`"
  
  echo 
  echo 'Reverted all files that only have mergeinfo changes'
}

# reverts all files
function svn_revert_all() {
  svn revert -R .
}

# make new branch off trunk and switch to it
function svn_branch() {
  branch=$1
  if [ -z "$branch" ]; then
    svn list '^/branches'
  else
    if [ "$(svn_get_branch_name)" != 'trunk' ]; then
      echo 'You must be on trunk'
      return
    fi  
    
    svn copy '^/trunk' "^/branches/$branch"
  fi
}

# switch between branches
function svn_switch() {
  branch=$1
  if [ -z "$branch" ]; then
    echo 'Switch where?'
    return
  fi
  
  where='^/'
  if [ "$branch" != 'trunk' ]; then
    where+='branches/' 
  fi
  where+=$branch
  
  svn switch "$where"
}
