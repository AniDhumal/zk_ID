# zk_ID

This project demonstrates how age verification can be achieved in zero knowledge fashion. It utilizes a contract which uses SBTs to maintain ownership records and a circom circuit to generate a proof of age. The generateProof contains all the functions needed to generate and verify proof as well as deploy the contract. 
An on-chain verifier can also be found in the contracts folder. 
The base repo was created using Shield CLI.

Try running some of the following tasks:

## Compile & Build

To Build circuits and compile contracts, use the build task:

```shell

npm run build
```

To compile contracts, use the task:

```shell

npm run compile
```

To compile and build circuits, use the task:

```shell

shield compile
```

## Debug & Generate Witness

```
shield debug
```

## Clean

clean the compiled artifacts saved in the artifacts/:

```shell

npm run clean
```

clean the compiled circuit build files saved in the circuits/build:

```shell

npm run clean:circuits
```

## Running Tests

To run tests, run the following command

```shell

  npm run test
```

## Deployment

To deploy this project on localhost run :

```bash

  npm run node
  npm run deploy:localhost

```
