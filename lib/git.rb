require 'open3'
class Git

	TMP_LOCATION = '/tmp/webhook'

	def self.get_contents(repo_url, file_paths_and_commits)
		# Make a directory for this repo
		directory = "#{TMP_LOCATION}/#{repo_url.gsub(/[^a-zA-Z0-9\-_]/, '')}#{Random.new.rand(1000000000)}"
		system('mkdir', '-p', TMP_LOCATION)

		content, stderr, status = Open3.capture3('git', 'clone', '--no-checkout', '--depth', '1', repo_url, directory)
		raise 'git clone failed' unless status.success?

		file_paths_and_commits.each do |file_path, commit|
			content, stderr, status = Open3.capture3('git', 'show', "#{commit}:#{file_path}", chdir: directory)
			raise 'git show failed' unless status.success?
			yield [file_path, commit, content]
		end
		system('rm', '-rf', directory)
	end

end

