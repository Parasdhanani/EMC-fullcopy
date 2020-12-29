import {
    LightningElement
} from 'lwc';

export default class AccordionComponent extends LightningElement {
    clickHandler(event) {
        // data-id of row <tr> -- >
        let targetId = event.currentTarget.dataset.id;
        console.log(targetId);
        let rowList = this.template.querySelectorAll(
            `[data-id="${targetId}"],.content`
        );
        console.log(rowList);
        var i;
        var j = rowList.length;
        //Hide show accordion on each row click Starts -->
        for(i=0;i<rowList.length;i++)
        {
            let row=rowList[i];
            if(row.className === 'content')
            {
                if(targetId === row.dataset.id)
                {
                    if(row.style.display === "table-row")
                        row.style.display = "none";
                    else
                        row.style.display = "table-row";
                }
            }
        }
        //Hide show accordion on each row click Ends -->
    }
}