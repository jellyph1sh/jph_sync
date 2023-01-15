fx_version "cerulean"
game "gta5"

version "1.0"
description "Synchronize time to real time and weather between all clients."
author "JellyPhish"

client_script "cl_sync.lua"

server_script "sv_sync.lua"

shared_script "config.lua"
