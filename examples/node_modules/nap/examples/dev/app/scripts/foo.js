$(function(){
    
    document.body.innerHTML = JST['hello'].render({
        world: 'Hogan'
    });
    
});