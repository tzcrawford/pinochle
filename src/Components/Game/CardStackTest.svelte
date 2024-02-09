<script lang="ts">
import CardStack from './CardStack.svelte'
</script>

<div class="card-stack-test" style="margin:2em">
    <div style="display: block">
        <div style="display: flex; justify-content: center;">
            <div style="transform:rotate(0);">
                <CardStack />
            </div>
        </div>
    </div>
    <div style="display: block">
        <div style="display: flex; justify-content: center">
            <div style="transform:rotate(90deg);">
                <CardStack />
            </div>
        </div>
    </div>
    <br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
    <div style="display: block">
        <div style="display: flex; justify-content: center">
            <div style="transform:rotate(270deg);">
                <CardStack />
            </div>
        </div>
    </div>
    <div style="display: block">
        <div style="display: flex; justify-content: center">
            <div style="transform:rotate(45deg);">
                <CardStack overlap="-4.8em" />
            </div>
        </div>
    </div>
    <br /><br /><br /><br /><br /><br /><br />
</div>
