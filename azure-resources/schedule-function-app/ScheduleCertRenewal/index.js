module.exports = async function (context, myTimer) {
    var timeStamp = new Date().toISOString();

    context.log('Triggered Certification renewal!', timeStamp);   

    const ACI = require('azure-arm-containerinstance');
    const AZ = require('ms-rest-azure');

    AZ.loginWithServicePrincipalSecret(process.env.SP_NAME, process.env.SP_KEY, process.env.TENNANT_ID, (err, cred, subs)=> {
        if (err)
        {
            throw err;
        } 
        var client = new ACI(cred, process.env.SUBSCRIPTION_ID);
        client.containerGroups.beginStart(process.env.ACI_RESOURCEGROUP, process.env.ACI_CONTAINERGROUP, () => {
            timeStamp = new Date().toISOString();
            context.log('Container group started.', timeStamp);   
        })

    })


};