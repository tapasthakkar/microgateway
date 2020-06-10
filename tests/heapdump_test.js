const heapdump = require('heapdump');
const cluster = require('cluster');

const heapdumpPath = process.env.EMG_HEAPDUMP_PATH;
const heapdumpInterval = process.env.EMG_HEAPDUMP_INTERVAL;



module.exports.masterHeapDump = function(){
    let counter = 0;
    setInterval(()=>{
        counter++
        heapdump.writeSnapshot(heapdumpPath+'/master_'+counter +'_'+ Date.now() + '.heapsnapshot');
    },1000*heapdumpInterval);

}

module.exports.workerHeapDump = function(){
    let counter = 0;
    setInterval(()=>{
        counter++;
        heapdump.writeSnapshot(heapdumpPath+'/worker_'+ cluster.worker.id+'_' + counter +'_'+ Date.now() + '.heapsnapshot');
    },1000*heapdumpInterval);

}
