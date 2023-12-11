<!--
Authentication : Manages user authentication.
-->

<script lang="ts">
    import { writable } from 'svelte/store'
    import { isRequiredFieldValid } from '../../SharedComponents/BoilerplateFunctions.js'

    import PopUpWindow from '../../SharedComponents/PopUpWindow.svelte'
    import LoginForm from './LoginForm.svelte'
    import Signup from './Signup.svelte'

    // A writable store to hold the JWT token
    import { authToken, loginWindowEnabled, newUserWindowEnabled} from '../../SharedComponents/store.js'

</script>

<PopUpWindow
    showPopUp={$loginWindowEnabled === "true" && $authToken === null}
    on:click={() => $loginWindowEnabled="false" }
    maxWidth="480px" additionalStyle=""
>
    <LoginForm />
</PopUpWindow>
<PopUpWindow
    showPopUp={$newUserWindowEnabled === "true" && $authToken === null}
    on:click={() => {newUserWindowEnabled.set("false"); loginWindowEnabled.set("true")}}
    maxWidth="480px" additionalStyle=""
>
    <Signup />
</PopUpWindow>

<style>
</style>
