import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

const client = new SuiClient({ url: "https://sui-mainnet-rpc.nodereal.io/" });

// input the address of VeSCA key, and get the info.
const vesca_address = "0x88e811a81d1e32ca65373c5f3a5d725da35a844603df277ad60af91c6532add6";

let result = await client.getDynamicFieldObject({
    parentId: "0x0a0b7f749baeb61e3dfee2b42245e32d0e6b484063f0a536b33e771d573d7246",
    name: {
        type: "0x2::object::ID",
        value: vesca_address, // this is the address of VeSCA, letf others alone
    }
});

console.log("The address of VeSCA is: ",vesca_address);
console.log("locked_sca_amount: ", result.data.content.fields.value.fields.locked_sca_amount);
console.log("unlock at: ", result.data.content.fields.value.fields.unlock_at);

// change string to int
let unlock_at = parseInt(result.data.content.fields.value.fields.unlock_at);
let locked_sca_amount = parseInt(result.data.content.fields.value.fields.locked_sca_amount);


// the unlock at is unix time stamp, change it to human readable one.
function unixToHumanReadable(unixTimestamp) {
    // Create a new Date object using the Unix timestamp
    const date = new Date(unixTimestamp * 1000);  
    // Format the date as a string
    return date.toLocaleString();
}

// the decimal of SCA is 9
const decimal = 9;
let converted_sca_amount = locked_sca_amount / Math.pow(10,decimal);


console.log(converted_sca_amount," SCA will be unlocked at:", unixToHumanReadable(unlock_at));

function calculateVeSCA(scaAmount, unlockTime) {
    const currentTime = Math.floor(Date.now() / 1000); // Current time in seconds
    const fourYearsInSeconds = 4 * 365 * 24 * 60 * 60; // 4 years in seconds
    
    // Calculate the remaining lock period in seconds
    const remainLockPeriod = Math.max(0, unlockTime - currentTime);
    
    // Calculate veSCA using the provided formula
    const veSCA = scaAmount * (remainLockPeriod / fourYearsInSeconds);
    
    return veSCA;
  }

  console.log(`veSCA amount: ${calculateVeSCA(converted_sca_amount, unlock_at)}`);
