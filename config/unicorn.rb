# -*- coding: utf-8 -*-
#
# Copyright 2015 Roy Liu
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

# Use at least one worker per core if you're on a dedicated server.
worker_processes 4

# Listen on a TCP port.
listen 8080, tcp_nopush: true

# Set output filenames for PIDs and logging.
pid "tmp/pids/unicorn.pid"
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

# For memory savings on Ruby 2.0.
preload_app true
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

# Enable this flag to have unicorn test client connections by writing the beginning of the HTTP headers before calling
# the application. This prevents calling the application for connections that have disconnected while queued.
check_client_connection false

before_fork do |server, worker|
  # There's no need for the master process to hold a database connection.
  ActiveRecord::Base.connection.disconnect! if defined?(ActiveRecord::Base)
end

after_fork do |server, worker|
  # Reestablish the database connection in the child process.
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
