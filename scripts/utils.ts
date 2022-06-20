const fs = require("fs");
const os = require("os");
import hre from 'hardhat'

export function setContractEnvValue(key: string, value: string) {
    setEnvValue(hre.network.name.toUpperCase() + "_" + key, value);
}

export function setEnvValue(key: string, value: string) {
    // read file from hdd & split if from a linebreak to a array
    const ENV_VARS = fs.readFileSync("./.env", "utf8").split(os.EOL);
    
    // find the env we want based on the key
    const target = ENV_VARS.indexOf(ENV_VARS.find((line: string) => {
        return line.match(new RegExp(key));
    }));
    // replace the key/value with the new value
    ENV_VARS.splice(target, 1, `${key}=${value}`);

    // write everything back to the file system
    fs.writeFileSync("./.env", ENV_VARS.join(os.EOL));
  }
  
export function log(logLevel: number, msg: string) {
    if (logLevel > 0){
      console.log(msg);
    }
  }