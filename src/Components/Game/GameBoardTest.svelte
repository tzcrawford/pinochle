<!--
GameBoard : Holds all game elements once entering the game
-->

<script lang="ts">
import CardStack from './CardStack.svelte'
</script>
<div class="game-board-cont0">
    <div class="game-board-cont1">
        <div class="left-player0">
            <div class="left-player1">
                <div class="left-player2">
                    <CardStack />
                </div>
            </div>
        </div>
        <div class="top-and-bottom-players0">
            <div class="top-and-bottom-players1">
                <div class="top-player1">
                    <div class="top-player2">
                        <CardStack />
                    </div>
                </div>
                <div class="bottom-player1">
                    <div class="bottom-player2">
                        <CardStack />
                    </div>
                </div>
            </div>
        </div>
        <div class="right-player0">
            <div class="right-player1">
                <div class="right-player2">
                    <CardStack />
                </div>
            </div>
        </div>
    </div>
</div>

<style>
div.game-board-cont0 {
    height: 100vh;
    width: 100vw;
    overflow: hidden;
}
div.game-board-cont1 {
    display: grid;
    grid-template-columns: 20% 60% 20%;
    width: 100%;
    height: 100%;
}

div.left-player0 {
    width: 30%;
    height: 100%;
}
div.right-player0 {
    width: 30%;
    height: 100%;
}
div.top-and-bottom-players0 {
    width: 40%;
    height: 100%;
}
div.top-and-bottom-players1 {
    display: flex;
    justify-content: center;
    flex-direction: column;
    height: 100%;
}


div.left-player1 {
    display: flex;
    justify-content: center;
}
div.right-player1 {
    display: flex;
    justify-content: center;
}

div.left-player2 {
    transform: rotate(90deg);
}
div.right-player2 {
    transform: rotate(-90deg);
}
div.top-player1 {
}
div.bottom-player1 {
}
div.top-player2 {
    display: flex;
    justify-content: center;
}
div.bottom-player2 {
    display: flex;
    justify-content: center;
}

</style>
