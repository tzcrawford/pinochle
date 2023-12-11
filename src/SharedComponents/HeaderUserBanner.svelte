<!--
    HeaderUserBanner: Details quick information about the user if they are logged in. 
    Or offers them a link to log in.
-->
<script lang="ts">
    import { slide } from 'svelte/transition'

    import { username } from './store.js'
    import { userSkillLevel } from './store.js'
    import { loginWindowEnabled } from './store.js'
    import { authToken } from './store.js'
    let userGamesPlayed
    let userWLRat
    let userLocation
    let userLanguage
</script>

<div class="BannerBlock">
    {#key username, userSkillLevel, userGamesPlayed, userWLRat, userLocation, userLanguage}
        {#if $username === null && $authToken === null}
            <div class="slide-transition" 
                 in:slide={{ duration: 1000, delay: 100, axis: 'x' }} 
                 out:slide={{ duration: 100, delay:   0, axis: 'x' }}
                 on:click|self={() => {
                    loginWindowEnabled.set("true") ;
                    }
                 }
            >
                Not logged in
            </div>
        {:else}
            <div class="slide-transition" 
                 in:slide={{ duration: 1000, delay: 100, axis: 'x' }} 
                 out:slide={{ duration: 100, delay:   0, axis: 'x' }}
            >
                <table class="userBannerContent">
                    <tr>
                        <td>
                            User:
                        </td><td>
                            <strong>{$username}</strong>
                        </td><td>
                            Skill Level:
                        </td><td>
                            <strong>{$userSkillLevel}</strong>
                        </td>
                    </tr><tr>
                        <td>
                            Games Played:
                        </td><td>
                            <strong>{userGamesPlayed}</strong>
                        </td><td>
                            W/L Ratio:
                        </td><td>
                            <strong>{userWLRat}</strong>
                        </td>
                    </tr><tr>
                        <td>
                            Location:
                        </td><td>
                            <strong>{userLocation}</strong>
                        </td><td>
                            Language:
                        </td><td>
                            <strong>{userLanguage}</strong>
                        </td>
                    </tr>
                </table>
            </div>
        {/if}
    {/key}
</div>

<style>
    .BannerBlock {
        /* Center the content vertically*/
        display: flex;
        flex-direction: column;
        justify-content: center; 

        height: 100%;
        max-width: 600px;
        background-color: #aaaaaa;
        text-align: center;
        padding: 0px 20px;
        margin: auto;
    }
    table.userBannerContent {
        text-align: right;
    }
    td {
        padding: 0 10px;
    }
    
    .slide-transition {
        white-space: nowrap;
    }
</style>

