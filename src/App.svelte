<!--
App : The main component that handles the overall structure of your app.
    * Manages routing between menus
-->

<script lang="ts">
    // Import svelte packages
    import { onMount } from 'svelte'
    import { writable } from 'svelte/store'

    // Collect user config
    import { fetchConfig } from './Components/SharedComponents/configService.js'
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
    
    import { userSkillLevel, config } from './Components/SharedComponents/store.js'
    import Authentication from './Components/Authentication/Authentication.svelte'
    import Header from './Components/SharedComponents/Header.svelte'
    import HeaderUserBanner from './Components/SharedComponents/HeaderUserBanner.svelte'
    import MainPageContent from './Components/MainPageContent.svelte'
    import Footer from './Components/SharedComponents/Footer.svelte'

</script>

<main>
    {#if $config !== null}
        <Authentication />
        <Header><HeaderUserBanner /></Header>
        <MainPageContent />
        <Footer />
    {:else}
        <p>Loading...</p>
    {/if}
</main>

<style>
</style>
