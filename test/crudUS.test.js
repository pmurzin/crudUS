const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const web3 = new Web3(ganache.provider());

const { interface, bytecode } = require('../compile');

let crudUS;
let accounts;

beforeEach(async () => {
    accounts = await web3.eth.getAccounts();

    crudUS = await new web3.eth.Contract(JSON.parse(interface))
                        .deploy({ data: bytecode})
                        .send({ from: accounts[0], gas: '1000000' });
});

describe('crudUS Contract', () => {
    it('deploys a contract', () => {
        assert.ok(crudUS.options.address);
    });

    it('does not allow for duplicates', async () => {
        await crudUS.methods.createState("CA","Some diet").send({
            from: accounts[0]
        });
        try {
            await crudUS.methods.createState("CA","newDiet").send({
                from: accounts[0]
            });
            assert(false);
        } catch (err) {
            assert(err);
        }
    });
    
    it('could not delete state that has not been added yet', async () => {
        try {
            await crudUS.methods.deleteState("FL").send({
                from: accounts[0],
            });
            assert(false); 
        } catch (err) {
            assert(err);
        }
    });
    it('only manager can update info about States&Cities', async () => {
        try {
            await crudUS.methods.updateStateDiet("CA","newDiet").send({
                from: accounts[1]
            });
            assert(false);
        } catch (err) {
            assert(err);
        }
    });

    
});
