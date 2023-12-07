<!--
App : The main component that handles the overall structure of your app. 
    * Manages routing between menus
-->

<script lang="ts">
    import { writable } from 'svelte/store'
    import { authToken } from './SharedComponents/store.js'
    import Authentication from './Panels/Authentication/Authentication.svelte'
    
    /*** Get random number in header ***/
    function getRand() {
        fetch("./rand")
        .then(d => d.text())
        .then(d => (rand = d));
    }
    let rand = getRand();
    
</script>

<main>
    <h1>Your number is {rand}!</h1>
    <button on:click={getRand}>Get a random number</button>
    <br /><br /><br /><br />
    {#if $authToken === null}
        <Authentication />
    {/if}
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

    @media (min-width: 640px) {
        main {
            max-width: none;
        }
    }
</style>
