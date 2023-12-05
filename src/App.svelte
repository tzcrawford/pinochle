<script lang="ts">
/*** Get random number in header ***/
export let name;
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

    if (loginFetch.ok) {
        errInputLoginRequestFail = false
        loginPostResponse = await loginFetch.json()
    } else {
        errInputLoginRequestFail = true
        return false
    }

    if(loginPostResponse == false ) {
        errInputLoginIncorrect = true
        return false
    } else {
        errInputLoginIncorrect = false
        console.log("Login Successful")
        return true
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
        <p class="error">Failed to POST Login Details to Server.</p>
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
