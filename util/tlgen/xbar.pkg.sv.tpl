// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tl_${xbar.name} package generated by `tlgen.py` tool

<%
  name_len = max([len(x.name) for x in xbar.devices])
%>\
package tl_${xbar.name}_pkg;

% for device in xbar.devices:
  ## Address
  localparam logic [31:0] ADDR_SPACE_${device.name.upper().ljust(name_len)} = 32'h ${"%08x" % device.address_from};
% endfor

% for device in xbar.devices:
  ## Mask
  localparam logic [31:0] ADDR_MASK_${device.name.upper().ljust(name_len)} = 32'h ${"%08x" % (device.address_to -
  device.address_from)};
% endfor

  localparam int N_HOST   = ${len(xbar.hosts)};
  localparam int N_DEVICE = ${len(xbar.devices)};

  typedef enum int {
% for device in xbar.devices:
  ## Create enum type for hosts( or blocks) connecting to the device
  ## Device Node has one upstream port. So tl_device_h2d can be directly used
<%
  u_name = ''.join(device.name.title().split('_'));
%>\
  % if loop.last:
    Tl${u_name} = ${loop.index}
  % else:
    Tl${u_name} = ${loop.index},
  % endif
% endfor
  } tl_device_e;

  typedef enum int {
% for host in xbar.hosts:
  ## Create enum type for downstream connecting to each host
  ## Host Node has one downstream port. so tl_host_h2d can be directly used
<%
  u_name = ''.join(host.name.title().split('_'));
%>\
  % if loop.last:
    Tl${u_name} = ${loop.index}
  % else:
    Tl${u_name} = ${loop.index},
  % endif
% endfor
  } tl_host_e;

endpackage