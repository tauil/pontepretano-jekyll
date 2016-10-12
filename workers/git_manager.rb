class GitManager
  def self.manage
    return if ENV['GIT']
    git = Git.open('./')

    # https://github.com/schacon/ruby-git/issues/136#issuecomment-61843461
    git_files = `git --work-tree=#{git.dir} --git-dir=#{git.dir}/.git ls-files -z -d -m -o -X .gitignore`.split("\x0")
    untracked = git.status.untracked.keys & git_files

    if untracked.any?
      puts "Pulling data..."
      git.pull

      untracked.each do |u|
        puts "Adding #{u} to repo..."
        git.add(u) if u.match('_posts/')
      end

      if git.status.added.any?
        puts "Commiting"
        git.commit('Adds a new parsed post')
        puts "Pushing code..."
        git.push('origin', 'gh-pages')
        true
      else
        puts "Nothing to commit"
        false
      end
    end
  end
end
