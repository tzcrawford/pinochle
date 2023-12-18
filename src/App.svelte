<!--
App : The main component that handles the overall structure of your app.
    * Manages routing between menus
-->

<script lang="ts">
    // Import svelte packages
    import { onMount } from 'svelte'
    import { writable } from 'svelte/store'

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
    
    import { userSkillLevel, config } from './SharedComponents/store.js'

    import Header from './SharedComponents/Header.svelte'
    import HeaderUserBanner from './SharedComponents/HeaderUserBanner.svelte'
    import Footer from './SharedComponents/Footer.svelte'

    import Authentication from './Panels/Authentication/Authentication.svelte'
    import Signup from './Panels/Authentication/Signup.svelte'
    
    import DropShadowTile from './SharedComponents/DropShadowTile.svelte'

</script>

<main>
    {#if $config !== null}
        <Header><HeaderUserBanner /></Header>
        <Authentication />
        <div style="display: flex; justify-content: center;">
            <DropShadowTile additionalStyle="width: 200px;margin: 1em">Test shadow tile</DropShadowTile>
        </div>
        <Footer />
    {:else}
        <p>Loading</p>
    {/if}
</main>

<style>
</style>
