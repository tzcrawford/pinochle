<!--
App : The main component that handles the overall structure of your app.
    * Manages routing between menus
-->

<script lang="ts">
    // Import svelte packages
    import { onMount } from 'svelte'
    import { writable } from 'svelte/store'

    import { userSkillLevel, config } from './SharedComponents/store.js'

    // Collect user config
    import { fetchConfig } from './SharedComponents/configService.js'
    let configResponse
    onMount(async () => {
    try {
        console.log("Fetching config...");
        const configResponse = await fetchConfig();
        console.log("Config fetched:", configResponse);
        config.set(configResponse)
        //console.log("Config saved to svelte store, it translates to", JSON.stringify($config))
    } catch (error) {
        console.error("Error fetching config:", error.message);
    }
    });


    //import PopUpWindow from './SharedComponents/PopUpWindow.svelte'


    import Header from './SharedComponents/Header.svelte'
    import HeaderUserBanner from './SharedComponents/HeaderUserBanner.svelte'
    import Footer from './SharedComponents/Footer.svelte'

    import Authentication from './Panels/Authentication/Authentication.svelte'

    /*** Get random number in header ***/
    let rand
    function getRand() {
        fetch("./rand")
        .then(d => d.text())
        .then(d => (rand = d));
    }
    getRand();
    $: userSkillLevel.set(rand)

</script>

<main>
    {#if $config !== null}
        <Header><HeaderUserBanner /></Header>
        <Authentication />
        <h2>Your number is {rand}!</h2>
        <button on:click={getRand}>Get a random number</button>
        <br /><br /><br /><br />
        <Footer />
    {:else}
        <p>Loading</p>
    {/if}
</main>

<style>
</style>
