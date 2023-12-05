<script lang="ts">
import { writable } from 'svelte/store';

/*** Holds page title (delete this later) ***/
export let name;

/*** Get random number in header ***/
function getRand() {
    fetch("./rand")
    .then(d => d.text())
    .then(d => (rand = d));
}
let rand = getRand();

/*** Form Validation Boilerplate ***/
function isRequiredFieldValid(value){
    return value != null && value !== ""
}

/*** Handle user login ***/
export const authToken = writable(null) // A writable store to hold the JWT token
let errInputLoginMissing = false
let errInputLoginIncorrect = false
let errInputLoginRequestFail = false
let valLoginUsername = null
let valLoginPassword = null
async function onLoginSubmit(e) {
    const loginFormData = new FormData(e.target);
    const loginData = {};
    for (let field of loginFormData) {
        const [key, value] = field;
        loginData[key] = value;
    }

    // Validate loginData was entered
    if(!( 
        isRequiredFieldValid(loginData.username) && isRequiredFieldValid(loginData.password)
    )){
        errInputLoginMissing = true
        return null
    } else {
        errInputLoginMissing = false
    }

    let loginPostResponse = null
    const loginFetch = await fetch('/login', {
        method: 'POST',
        body: JSON.stringify({ valLoginUsername, valLoginPassword }),
        headers: {
            'Content-Type': 'application/json'
        }
    });

    if (loginFetch.status === 200) { // Login was successful.
        loginPostResponse = await loginFetch.json()
        errInputLoginRequestFail = false
        errInputLoginIncorrect = false
        console.log("Login Successful")
        authToken.set(loginPostResponse.access_token)
        console.log("JWT Token Stored")
        return true
    } else if (loginFetch.status === 401){ // UN/PW probably didn't match.
        errInputLoginIncorrect = true
        errInputLoginRequestFail = false
        return false
    } else { // Possibly server connection isn't working out or there is a code bug.
        errInputLoginRequestFail = true
        errInputLoginIncorrect = false
        return false
    }
};
</script>

<main>
    <h1>Hello {name}!</h1>
    <p>Visit the <a href="https://svelte.dev/tutorial">Svelte tutorial</a> to learn how to build Svelte apps.</p>
    
    <h1>Your number is {rand}!</h1>
    <button on:click={getRand}>Get a random number</button>

    <br /><br /><br /><br />

    <form on:submit|preventDefault={onLoginSubmit}>
    <div>
        <label for="inputLoginUsername">username:</label>
        <input
            type="text"
            id="inputLoginUsername"
            name="username"
            bind:value={valLoginUsername}
        />
    </div>
    <div>
        <label for="inputLoginPassword">Password:</label>
        <input
            type="password"
            id="inputLoginPassword"
            name="password"
            bind:value={valLoginPassword}
        />
    </div>
    <button type="btnLoginSubmit">Submit</button>
    {#if errInputLoginMissing }
        <p class="error">Username/Password Required.</p>
    {/if}
    {#if errInputLoginIncorrect }
        <p class="error">Invalid Username/Password Entry.</p>
    {/if}
    {#if errInputLoginRequestFail }
        <p class="error">Failed to POST Login Details to Server.
        {#if loginFetch.message }
            <p class="error">Error message: {loginFetch.message}</p>
        {/if}
        </p>
    {/if}
    </form>

</main>

<style>
    main {
        text-align: center;
        padding: 1em;
        max-width: 240px;
        margin: 0 auto;
    }

    h1 {
        color: #ff3e00;
        text-transform: uppercase;
        font-size: 4em;
        font-weight: 100;
    }

    p.error {
        color: red; 
        font-weight: bold;
    }

    @media (min-width: 640px) {
        main {
            max-width: none;
        }
    }
</style>
