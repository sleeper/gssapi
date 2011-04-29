#############################################################################
# Copyright © 2010 Dan Wanek <dan.wanek@gmail.com>
#
#
# This file is part of the Ruby GSSAPI library.
# 
# GSSAPI is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or (at
# your option) any later version.
# 
# GSSAPI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
# Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with GSSAPI.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################
module GSSAPI
  module LibGSSAPI

    # Heimdal supported the *_iov functions befor MIT did so in some OS distributions if
    # you need IOV support and MIT does not provide it try the Heimdal libs and then
    # before doing a "require 'gssapi'" do a "require 'gssapi/heimdal'" and that will attempt
    # to load the Heimdal libs
    case RUBY_PLATFORM
    when /linux/
      case GSSAPI_LIB_TYPE
      when :mit
        GSS_LIB_PATH = File.basename(Dir.glob("/usr/lib/libgssapi_*").sort.first)
      when :heimdal
        %w{/usr/lib/libgssapi.so.2 /usr/lib64/heimdal/libgssapi.so.2 /usr/lib64/heimdal/libgssapi.so.2}.each do |p|
          if File.exists?(p)
            GSS_LIB_PATH = p
            break
          end
        end
      end
      ffi_lib GSS_LIB_PATH, FFI::Library::LIBC
    when /darwin/
      case GSSAPI_LIB_TYPE
      when :mit
        GSS_LIB_PATH = '/usr/lib/libgssapi_krb5.dylib'
      when :heimdal
        # use Heimdal Kerberos since Mac MIT Kerberos is OLD. Do a "require 'gssapi/heimdal'" first
        GSS_LIB_PATH = '/usr/heimdal/lib/libgssapi.dylib'
      end
      ffi_lib GSS_LIB_PATH, FFI::Library::LIBC
    when /mswin|mingw32|windows/
      ffi_lib 'gssapi32'  # Required the MIT Kerberos libraries to be installed
      ffi_convention :stdcall
    else
      raise LoadError, "This platform (#{RUBY_PLATFORM}) is not supported by ruby gssapi."
    end

  end
end
