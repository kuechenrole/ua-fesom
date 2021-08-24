#!/bin/bash

scp -r $timmsoutdir linsrv1:/isibhv/netscratch/orichter/timms/.    
scp -r $fesommeshdir linsrv1:/isibhv/netscratch/orichter/fesommesh/.
scp -r $uadir linsrv1:/isibhv/netscratch/orichter/ua/.
scp -r $fesomrundir linsrv1:/isibhv/netscratch/orichter/fesomrun/.
scp -r $fesomdata linsrv1:/isibhv/netscratch/orichter/fesomdata/.

