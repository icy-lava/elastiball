local system: tiny.System<any> = tiny.system()

system.filter = tiny.requireAll('pos', 'lastPos', 'pinned')

return system