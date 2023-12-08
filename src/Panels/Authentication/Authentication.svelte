<!--
Authentication : Manages user authentication.
-->

<script lang="ts">
    import { writable } from 'svelte/store'
    import { isRequiredFieldValid } from '../../SharedComponents/BoilerplateFunctions.js'

    import PopUpWindow from '../../SharedComponents/PopUpWindow.svelte'

    // A writable store to hold the JWT token
    import { authToken, username } from '../../SharedComponents/store.js'

    /*** Handle user login ***/

    let errInputLoginMissing = false
    let errInputLoginIncorrect = false
    let errInputLoginRequestFail = false
    let valLoginUsername = null
    let valLoginPassword = null
    let loginFetchResult

    async function onLoginSubmit(e) {

        const loginFormData = new FormData(e.target)
        const loginData = {}
        for (let field of loginFormData) {
            const [key, value] = field
            loginData[key] = value
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


        try { // This is to prevent silent errors. we can fail on setting $authToken, so instead we just kick right back to login menu if that happens
            let loginPostResponse = null
            loginFetchResult = await fetch('/login', {
                method: 'POST',
                body: JSON.stringify({ valLoginUsername, valLoginPassword }),
                headers: {
                    'Content-Type': 'application/json'
                }
            })

            if (loginFetchResult.status === 200) { // Login was successful.
                loginPostResponse = await loginFetchResult.json()
                errInputLoginRequestFail = false
                errInputLoginIncorrect = false
                console.log("Login Successful")
                authToken.set(loginPostResponse.access_token) // Make sure not to do $authtoken.set with a dollar sign
                username.set(loginPostResponse.username) // Make sure not to do $authtoken.set with a dollar sign
                console.log("Auth token saved to Svelte store")
                return true
            } else if (loginFetchResult.status === 401){ // UN/PW probably didn't match.
                errInputLoginIncorrect = true
                errInputLoginRequestFail = false
                return false
            } else { // Possibly server connection isn't working out or there is a code bug.
                errInputLoginRequestFail = true
                errInputLoginIncorrect = false
                return false
            }
        } catch (error) {
            console.error('Error fetching login response:', error)
            return false
        }
        finally {
        }
    }
</script>

<PopUpWindow
    showPopUp={$authToken === null} on:click={() => $authToken === null}
    maxWidth="480px" additionalStyle=""
>
    <div class="authContainer" >
        <form on:submit|preventDefault={onLoginSubmit}>
        <div>
            <label for="inputLoginUsername">Username:</label>
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
            {#if loginFetchResult.message }
                <p class="error">Error message: {loginFetchResult.message}</p>
            {/if}
            </p>
        {/if}
        </form>
    </div>
</PopUpWindow>

<style>
    p.error {
        color: red;
        font-weight: bold;
    }
    .authContainer {
        color: black;
        background-color: #f5f5f5;
        padding: 20px;
        text-align: center;
        border-radius: 10px;
    }
</style>
