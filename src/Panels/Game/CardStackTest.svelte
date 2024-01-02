<script lang="ts">
import CardStack from './CardStack.svelte'
</script>

<div class="card-stack-test" style="margin:2em">
    <div style="display: flex; justify-content: center;">
        <CardStack />
    </div>
    <div style="display: flex; justify-content: center;transform:rotate(90deg);">
        <CardStack />
    </div>
    <br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
    <div style="display: flex; justify-content: center;transform:rotate(270deg);">
        <CardStack />
    </div>
    <div style="display: flex; justify-content: center;transform:rotate(45deg);">
        <CardStack overlap="-4.8em" />
    </div>
</div>
