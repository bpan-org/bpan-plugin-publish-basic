#------------------------------------------------------------------------------
# Publish logic
#------------------------------------------------------------------------------
publish:run() (
  publish:setup
  publish:setup-basic

  if ! db:index-has-package "$index" "$package_id"; then
    publish:add-new-index-entry "$index_file_dir"
  fi

  publish:check

  $option_check && return

  publish:update-index Publish

  git -C "$index_file_dir" push bpan-publish

  say -g "Published '$package_id=$package_version'"

  html_url=$(publish:get-package-source)

  say "* Package: $html_url"
  say "* Index: $index_url"

  rm -fr "$index_file_dir"
)

publish:setup-basic() {
  package_version=$(git config -f .bpan/config package.version)

  index_file_dir=$PWD/.bpan/bpan-index
  index_file_path=$index_file_dir/$index_file_name

  index_url=$(ini:get index."$index".source)

  rm -fr "$index_file_dir"

  git clone --quiet \
    "$index_url" \
    "$index_file_dir"

  local push_url
  push_url=$(
    ini:get --file="$index_file_path" "plugin.publish.index-push-url" || {
      if [[ $index_url == https://github.com/* ]]; then
        url=git@${index_url#'https://'}
        echo "${url/\//:}"
      else
        echo "$index_url"
      fi
    }
  )

  git -C "$index_file_dir" \
    remote add "$app-publish" "$push_url"
}
