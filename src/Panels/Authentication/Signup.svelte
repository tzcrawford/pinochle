<!--
Signup : Queries database to create new user.
    * Username
    * Password
    * Email
    * Preferred Name (Optional)
    * Location
    * Language
    * Starting experience level
-->

<script lang="ts">
import { onMount } from 'svelte'; 
import { authToken, username } from '../../SharedComponents/store.js'
import { isRequiredFieldValid } from '../../SharedComponents/BoilerplateFunctions.js'

let errInputFieldsMissing = false
let errInputFieldsIncorrect = false
let errInputFieldsRequestFail = false
let errLocLangRequestFailMessage = false
let valNewUserUsername = null
let valNewUserPassword = null
let valNewUserEmail    = null
let valNewUserLanguage = null
let valNewUserLocation = null
let valNewUserCountry  = null
let createUserFetchResult
let languageData = []
let countryData = []

// Get the country and language data from the database
async function getLangLocData () {
    try {
        const languageDataResponse = await fetch('/languages')
        languageData = await languageDataResponse.json()
    } catch(error) {
        console.error('Error fetching language data from server.')
        errLocLangRequestFailMessage = error
    }
    try {
        const countryDataResponse = await fetch('/countries')
        countryData = await countryDataResponse.json()
    } catch(error) {
        console.error('Error fetching country data from server.')
        errLocLangRequestFailMessage = error
    }
}
onMount(() => {
    getLangLocData()
});

async function onCreateUserSubmit(e) {

    const createUserFormData = new FormData(e.target)
    const createUserData = {}
    for (let field of createUserFormData) {
        const [key, value] = field
        createUserData[key] = value
    }

    // Validate createUserData was entered
    if(!(
        isRequiredFieldValid(createUserData.username) &&
        isRequiredFieldValid(createUserData.password) &&
        isRequiredFieldValid(createUserData.email)
    )){
        errInputFieldsMissing = true
        return false
    } else {
        errInputFieldsMissing = false
    }

    try { 
        // This is to prevent silent errors. we can fail on setting $authToken, so instead w        e just kick right back to user creation menu if that happens
        let createUserPostResponse = null
        createUserFetchResult = await fetch('/new_user', {
            method: 'POST',
            body: JSON.stringify({ 
                valNewUserUsername, 
                valNewUserPassword,
                valNewUserEmail,
                valNewUserLanguage,
                valNewUserLocation,
                valNewUserCountry
            }),
            headers: {
                'Content-Type': 'application/json'
            }
        })

        if (createUserFetchResult.status === 200) { // Create user request was successful.
            createUserPostResponse = await createUserFetchResult.json()
            errInputFieldsRequestFail = false
            errInputFieldsIncorrect = false
            console.log("User Creation Successful")
            authToken.set(createUserPostResponse.access_token) // Make sure not to do $authtoken.se        t with a dollar sign
            username.set(createUserPostResponse.username) // Make sure not to do $authtoken.set wit        h a dollar sign
            console.log("Auth token saved to Svelte store")
            console.log("$Username and $authToken set")
            newUserWindowEnabled.set("false")
            return true
        } else if (createUserFetchResult.status === 401){ // UN/PW probably didn't match.
            errInputFieldsIncorrect = true
            errInputFieldsRequestFail = false
            return false
        } else { // Possibly server connection isn't working out or there is a code bug.
            errInputFieldsRequestFail = true
            errInputFieldsIncorrect = false
            return false
        }
    } catch (error) {
        console.error('Error fetching create user response:', error)
        return false
    }
    finally {
    }
}
</script>


<div class="signupContainer">
Enter the details for your new user below:
<br /><br />
{#if errLocLangRequestFailMessage }
    <p class="error">Failed to collect language/location list from server.
    {#if errLocLangRequestFailMessage }
        <p class="error">Error message: {errLocLangRequestFailMessage}</p>
    {/if}
    </p>
{/if}
<form on:submit|preventDefault={onCreateUserSubmit}>
<div>
    <label for="inputUsername">Username:</label>
    <input
        type="text"
        id="inputUsername"
        name="username"
        placeholder="username"
        bind:value={valNewUserUsername}
    />
</div>
<div>
    <label for="inputPassword">Password:</label>
    <input
        type="password"
        id="inputPassword"
        name="password"
        placeholder="password"
        bind:value={valNewUserPassword}
    />
</div>
<div>
    <label for="inputEmail">Email:</label>
    <input
        type="text"
        id="inputEmail"
        name="email"
        placeholder="email"
        bind:value={valNewUserEmail}
    />
</div>
<div>
    <label for="inputLocation">Location:</label>
    <input
        type="text"
        id="inputLocation"
        name="location"
        placeholder="location"
        bind:value={valNewUserLocation}
    />
</div>
<div>
    <label for="inputCountry">Country:</label>
    {#if countryData !== [] }
    <select
        id="inputCountry"
        name="country"
        placeholder="country"
        bind:value={valNewUserCountry}
        on:change={ (event) => {}}
    >
            {#each countryData as countryItem (countryItem["code"])}
                <option value={countryItem["code"]}>{countryItem["name"]}</option>
            {/each}
        </select>
    {:else}
        <p>Loading Location Data...</p>
    {/if}
</div>
<div>
    <label for="inputLanguage">Language:</label>
    {#if languageData !== [] }
        <select
            id="inputLanguage"
            name="language"
            placeholder="language"
            bind:value={valNewUserLanguage}
            on:change={ (event) => {}}
        >
            {#each languageData as langItem (langItem["ISO-639-1"])}
                <option value={langItem["ISO-639-1"]}>{langItem["language"]}</option>
            {/each}
        </select>
    {:else}
        <p>Loading Location Data...</p>
    {/if}
</div>

<button type="btnSignupSubmit">Submit</button>
{#if errInputFieldsMissing}
    <p class="error">Username/Password Required.</p>
{/if}
{#if errInputFieldsIncorrect}
    <p class="error">Invalid Username/Password Entry.</p>
{/if}
{#if errInputFieldsRequestFail}
    <p class="error">Failed to POST Create User Request to Server.
    {#if createUserFetchResult.message }
        <p class="error">Error message: {createUserFetchResult.message}</p>
    {/if}
    </p>
{/if}
</form>
</div>

<style>
p.error {
    color: red;
    font-weight: bold;
}
.signupContainer {
    color: black;
    background-color: #f5f5f5;
    padding: 20px;
    text-align: center;
    border-radius: 10px;
}
</style>
