<!--
    HeaderUserBanner: Details quick information about the user if they are logged in. 
    Or offers them a link to log in.
-->
<script lang="ts">
    import { onMount } from 'svelte'
    import { slide } from 'svelte/transition'

    import { username } from './store.js'
    import { userSkillLevel, userGamesPlayed, userWLRat, userLocation, userLanguage } from './store.js'
    import { loginWindowEnabled } from './store.js'
    import { authToken } from './store.js'

    async function get_user_stats($username) {
        if($username != null && $username != undefined) {
            try {
                console.log("Attempting to collect user stats for", $username)
                let userStatsPostResponse = null
                let userStatsFetchResult = null
                userStatsFetchResult = await fetch('/user_stats', {
                    method: 'POST',
                    body: JSON.stringify({ "username": $username }),
                    headers: {
                        'Content-Type': 'application/json'
                    }
                })

                if (userStatsFetchResult.status === 200) { // Successful.
                    userStatsPostResponse = await userStatsFetchResult.json()
                    console.log("userStatsPostRequest success")
                    $userGamesPlayed = userStatsPostResponse[0].games_played
                    $userLanguage    = userStatsPostResponse[0].language
                    $userSkillLevel  = userStatsPostResponse[0].current_skill
                    $userLocation    = String(userStatsPostResponse[0].location)
                        + ", " + String(userStatsPostResponse[0].country_code)
                    if(
                        userStatsPostResponse[0].games_played != 0 
                        && userStatsPostResponse[0].games_played !== null
                        && userStatsPostResponse[0].games_played !== undefined
                    ) {
                        $userWLRat = userStatsPostResponse[0].games_won / userStatsPostResponse[0].games_played
                    } else { $userWLRat = undefined }

                    return true
                } else { // Possibly server connection isn't working out or there is a code bug.
                    return false
                }
            } catch (error) {
                console.error('Error fetching user stats request response:', error)
                return false
            }
            finally {
            }
        }
    }
    
    onMount(() => {
        const unsubscribe = username.subscribe(get_user_stats);
        return () => {
            unsubscribe();
        }
    });
</script>

<div class="BannerBlock">
    {#key username, userSkillLevel, userGamesPlayed, userWLRat, userLocation, userLanguage}
    {#if $username === null && $authToken === null}
            <div class="userBannerLoginPrompt">
                <div class="slide-transition" 
                     in:slide={{ duration: 1000, delay: 100, axis: 'x' }} 
                     out:slide={{ duration: 100, delay:   0, axis: 'x' }}
                     on:click|self={() => {
                        loginWindowEnabled.set("true") ;
                        }
                     }
                     on:keypress={() => {}}
                >
                    Log In
                </div>
            </div>
        {:else}
            <div class="slide-transition" 
                in:slide={{ duration: 1000, delay: 100, axis: 'x' }} 
                out:slide={{ duration: 100, delay:   0, axis: 'x' }}
            >
            <table class="userBannerContent"
                on:click|self={() => {console.log("clicked"); get_user_stats($username)}}
                on:keypress={() => {}}
            > <!-- on:click not working for some reason? -->
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
                        <strong>{$userGamesPlayed}</strong>
                    </td><td>
                        W/L Ratio:
                    </td><td>
                        <strong>{$userWLRat}</strong>
                    </td>
                </tr><tr>
                    <td>
                        Location:
                    </td><td>
                        <strong>{$userLocation}</strong>
                    </td><td>
                        Language:
                    </td><td>
                        <strong>{$userLanguage}</strong>
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
        /*
        z-index:3;
        Goal with trying z-index is to get on:click to work, but it appears to not be working...
        */
    }
    td {
        padding: 0 10px;
    }
    
    .slide-transition {
        white-space: nowrap;
    }
    div.userBannerLoginPrompt {
        /*z-index:1;*/
    }

</style>

