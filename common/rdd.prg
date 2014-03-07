function index_tag_num(name)

if rddName() != "SQLMIX"
   return ordNumber(name)
else
   for i:=1 to ordCount()
         if ordKey(i) == name
              return i
         endif
   next
   return 0
endif

// dbf lock / unlock

function my_flock()

if rddName() != "SQLMIX"
    return FLOCK()
else
    return .t.
endif


function my_rlock()

if rddName() != "SQLMIX"
    return RLOCK()
else
    return .t.
endif




function my_unlock()

if rddName() != "SQLMIX"
    return DBUNLOCK()
else
    return .t.
endif


