import { getFullnodeUrl, SuiClient } from "@mysten/sui/client"

const client = new SuiClient({ url: "https://sui-mainnet-rpc.nodereal.io/" });

// input the address of VeSCA key, and get the info.
const vesca_address = "0xbfb3ead05b9ce64c9ee39ddb0ed6432ff9980f7559db7ebc304fe43093e17802";

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

