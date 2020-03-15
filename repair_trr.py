import os
from copy import deepcopy 
import sys

if len(sys.argv) < 3:
    raise SystemError('Usage: python old.trr new.trr')
if not os.path.exists(sys.argv[1]):
    raise IOError('%s does not exist.' %sys.argv[1])
new_trr = open(sys.argv[2],'wb')
filename = sys.argv[1]
with open(filename,'rb') as reader:
    gmx_magic_number = reader.read(30)
    reader.seek(0)
    size = 0
    old = None
    while reader.tell() < os.path.getsize(filename):
        try:
            tmp = reader.read(1000)
        except:
            new_trr.close()
            raise IOError('Bad reading.')
        if gmx_magic_number in tmp:
            if old and gmx_magic_number in old[29:]+tmp[:29]:
                size += (old+tmp).index(gmx_magic_number)-1000
                break
            elif not old:
                pass
            elif old and not gmx_magic_number in old[29:]+tmp[:29]:
                size += tmp.index(gmx_magic_number)
                break
        size += 1000
        old = deepcopy(tmp)
    if reader.tell() == os.path.getsize(filename):
        new_trr.close()
        raise StopIteration('Only one frame is found.')
    print("Each frame occupy %d bytes." %size)
    # repairing
    reader.seek(0)
    old = None
    count = 0
    while reader.tell() < os.path.getsize(filename):
        try:
            tmp = reader.read(size)
        except:
            new_trr.close()
            raise IOError('Bad reading.')  
        if not old:
            pass
        elif old and not tmp.startswith(gmx_magic_number):
            reader.seek(-2*size,1)
            tmp = reader.read(size*3)
            bad_size = (tmp[1:]).index(gmx_magic_number)+1
            reader.seek(-3*size,1)
            reader.read(bad_size)
            continue
        elif old and tmp.startswith(gmx_magic_number):
            new_trr.write(old)
        old = deepcopy(tmp)
        count += 1
    if len(old) < size:
        print('Last frame is broken.')
    else:
        new_trr.write(old)
new_trr.close()
print("Repair Finished.")